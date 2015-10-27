Arel::SelectManager.send(:include, Module.new do
  def projections
    @ctx.projections
  end
end)
